if Rails.env.test? || Rails.env.development?
  ActiveRecordQueryTrace.enabled
end
