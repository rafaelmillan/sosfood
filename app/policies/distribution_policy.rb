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
    record.organization == user
  end

  def destroy?
    record.organization == user
  end
end
