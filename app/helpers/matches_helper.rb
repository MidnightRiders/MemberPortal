module MatchesHelper
  def png_asset(path)
    return image_url(path) unless @embed_resources

    "data:image/png;base64,#{Base64.strict_encode64(Rails.application.assets.load_path.find(path).html_safe)}"
  end
end
