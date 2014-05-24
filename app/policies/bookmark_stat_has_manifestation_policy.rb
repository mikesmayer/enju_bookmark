class BookmarkStatHasManifestationPolicy < AdminPolicy
  def create?
    user.try(:has_role?, 'Administrator')
  end

  def update?
    user.try(:has_role?, 'Administrator')
  end

  def destroy?
    user.try(:has_role?, 'Administrator')
  end
end
