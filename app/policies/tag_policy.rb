class TagPolicy < AdminPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.try(:has_role?, 'User')
  end

  def update?
    user.try(:has_role?, 'Librarian')
  end

  def destroy?
    user.try(:has_role?, 'Librarian')
  end
end
