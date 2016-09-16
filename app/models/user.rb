class User < ActiveRecord::Base
  before_save :downcase_email
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end
end
