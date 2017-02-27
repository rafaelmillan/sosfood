class DistributionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def create?
    true
  end

  def update?
    record.organization.users.include? user
  end

  def destroy?
    record.organization.users.include? user
  end
end
