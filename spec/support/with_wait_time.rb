def with_wait_time(wait_time = Capybara.default_wait_time)
  previous_max_wait_time = Capybara.default_max_wait_time
  Capybara.default_max_wait_time = wait_time
  yield
ensure
  Capybara.default_max_wait_time = previous_max_wait_time
end
