require 'net/http'
require 'json'

token = ENV['TODOIST_API_TOKEN']
working_project_ids = ENV['TODOIST_WORKING_PROJECT_IDS'].split(',')

def get_completed_tasks(token, project_id)
  uri = URI("https://api.todoist.com/sync/v9/completed/get_all")
  # params = { token: token, project_id: project_id }
  # uri.query = URI.encode_www_form(params)
  res = Net::HTTP.get_response(uri, 'Authorization' => "Bearer #{token}")
  JSON.parse(res.body)
end

pp get_completed_tasks(token, '')
