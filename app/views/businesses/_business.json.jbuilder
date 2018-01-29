json.extract! business, :id, :offer, :description, :creator_id, :created_at, :updated_at
json.url business_url(business, format: :json)
json.user_roles business.user_roles    unless business.user_roles.empty?
