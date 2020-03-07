module MatchesHelper
  def png_asset(path)
    return image_url(path) unless @embed_resources

    "data:image/png;base64,#{Base64.strict_encode64(Rails.application.assets.find_asset(path).to_s)}"
  end
end
