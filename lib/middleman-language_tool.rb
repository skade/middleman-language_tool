require "middleman-core"
require "middleman-language_tool/version"

::Middleman::Extensions.register(:spellcheck) do
    require "middleman-language_tool/extension"
      ::Middleman::LanguageTool::LanguageToolExtension
end
