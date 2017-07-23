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
    record.organization.users.include?(user) || user.admin
  end

  def destroy?
    record.organization.users.include?(user) || user.admin
  end

  def accept?
    user.admin
  end

  def decline?
    user.admin
  end

  def pause?
    record.organization.users.include?(user) || user.admin
  end

  def unpause?
    record.organization.users.include?(user) || user.admin
  end
end
