json.array!(@permissions) do |permission|
  json.extract! permission, :id, :name, :action, :subject_class
  json.url permission_url(permission, format: :json)
end
