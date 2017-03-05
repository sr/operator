json.extract! build, :artifact_url, :repo_url, :build_id, :url, :branch, :build_number, :sha
json.created_at build.created_at.iso8601
json.passed_ci build.passed_ci?
json.compliant build.compliant?
