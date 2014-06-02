require 'nokogiri'
require 'language_tool'

module Middleman
  module LanguageTool
    class LanguageToolExtension < Extension
      REJECTED_EXTS = %w(.css .js .coffee)
      option :page, "/*", "Run only pages that match the regex through the spellchecker"
      option :tags, [], "Run spellcheck only on some tags from the output"
      option :allow, [], "Allow specific words to be misspelled"

      def after_build(builder)
        language_tool = ::LanguageTool::Process.new
        language_tool.start!
        spellchecker = ::LanguageTool::ErrorParser.new(language_tool)

        filtered = filter_resources(app, options.page)
        total_misspelled = []

        filtered.each do |resource|
          builder.say_status :spellcheck, "Running spell checker for #{resource.url}", :blue
          current_misspelled = run_check(spellchecker, select_content(resource))
          current_misspelled.each do |misspell|
            builder.say_status :misspell, error_message(misspell), :red
          end
          total_misspelled += current_misspelled
        end

        unless total_misspelled.empty?
          raise Thor::Error, "Build failed. There are spelling errors."
        end
      end

      def select_content(resource)
        rendered_resource = resource.render(layout: false)
        doc = Nokogiri::HTML(rendered_resource)

        if options.tags.empty?
          doc.text
        else
          select_tagged_content(doc, option_tags)
        end
      end

      def option_tags
        if options.tags.is_a? Array
          options.tags
        else
          [options.tags]
        end
      end

      def select_tagged_content(doc, tags)
        tags.map { |tag| texts_for_tag(doc, tag.to_s) }.flatten.join(' ')
      end

      def texts_for_tag(doc, tag)
        doc.css(tag).map(&:text)
      end

      def filter_resources(app, pattern)
        app.sitemap.resources.select { |resource| resource.url.match(pattern) }
                             .reject { |resource| REJECTED_EXTS.include? resource.ext }
      end

      def run_check(spellchecker, text)
        errors = spellchecker.find_errors(text)
        errors.reject { |e| e.ruleId == "WHITESPACE_RULE" }
        #results = exclude_allowed(results)
        #results.reject { |entry| entry[:correct] }
      end

      def exclude_allowed(results)
        results.reject { |entry| option_allowed.include? entry[:word].downcase }
      end

      def option_allowed
        allowed = if options.allow.is_a? Array
                    options.allow
                  else
                    [options.allow]
                  end
        allowed.map(&:downcase)
      end

      def error_message(misspell)
        "Category: #{misspell.category}\n" \
        "Message: #{misspell.msg}\n" \
        "Context: #{misspell.context}\n" \
        "Replacements: #{misspell.replacements.split('#').join(' ')}\n" \

        #"The word '#{misspell[:word]}' is misspelled"
      end
    end
  end
end
