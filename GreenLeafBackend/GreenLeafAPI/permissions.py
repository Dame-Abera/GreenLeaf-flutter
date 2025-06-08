from rest_framework import permissions

class IsOwner(permissions.BasePermission):
    """
    Custom permission to allow only owners of a plant to view or edit it.
    """

    def has_object_permission(self, request, view, obj):
        return obj.created_by == request.user
