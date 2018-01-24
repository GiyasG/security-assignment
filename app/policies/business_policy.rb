class BusinessPolicy < ApplicationPolicy
  def index?
    true
  end
  def show?
    organizer_or_admin?
  end
  def create?
    @user
  end
  def update?
    organizer?
  end
  def destroy?
    organizer_or_admin?
  end

  class Scope < Scope
    def user_roles members_only=true, allow_admin=true
      include_admin=allow_admin && @user && @user.is_admin?
      member_join = members_only && !include_admin ? "join" : "left join"
      joins_clause=["#{member_join} Roles r on r.mname='Business'",
                    "r.mid=Businesses.id",
                    "r.user_id #{user_criteria}"].join(" and ")
      scope.select("Businesses.*, r.role_name")
           .joins(joins_clause)
           .tap {|s|
             if members_only
               s.where("r.role_name"=>[Role::ORGANIZER, Role::MEMBER])
             end}
             # binding.pry
    end
    def resolve
      user_roles
      # byebug
    end
  end
end
