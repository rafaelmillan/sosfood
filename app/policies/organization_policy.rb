class OrganizationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end

    def show?
      true
    end
  end

  def create?
    @user.organization.nil?
  end
end
