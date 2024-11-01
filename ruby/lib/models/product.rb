require_relative '../../db/db_setup'

class Product < Sequel::Model
  plugin :timestamps

  def before_create
    self.created_at ||= Time.now
    self.updated_at ||= Time.now
    super
  end

  def before_update
    self.updated_at = Time.now
    super
  end
end
