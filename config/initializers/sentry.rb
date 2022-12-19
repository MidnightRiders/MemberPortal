puts Rake.application.top_level_tasks

if Rails.env.production? && !Rake.application.top_level_tasks.all? { /^assets:/i =~ _1 }
  Sentry.init do |config|
    config.dsn = 'https://bc9541d68fb243c89e2d97f20e2148fe@o4504330520100864.ingest.sentry.io/4504330521870336'
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.environment = Rails.env.to_s

    config.traces_sample_rate = 0.2
  end
end
