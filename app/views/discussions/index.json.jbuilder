json.array!(@discussions) do |discussion|
  json.extract! discussion, :id
  json.url discussion_url(discussion, format: :json)
end
