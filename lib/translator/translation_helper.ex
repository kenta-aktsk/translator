defmodule Translator.TranslationHelpers do
  def translate(model, field, assoc \\ :translation)
  def translate(nil, _field, _assoc), do: ""
  def translate(model, field, assoc) do
    translation = Map.get(model, assoc)
    if !is_nil(translation) && Ecto.assoc_loaded?(translation) && Map.has_key?(translation, field) do
      Map.get(translation, field)
    else
      Map.get(model, field)
    end
  end
end
