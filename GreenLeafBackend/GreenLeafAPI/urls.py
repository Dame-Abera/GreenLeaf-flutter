# For generic views
# from django.urls import path
# from . import views

# urlpatterns = [
#     path('plants/', views.PlantListCreateView.as_view(), name='plant-list-create'),
#     path('plants/<int:pk>/', views.PlantRetrieveUpdateDestroyAPIView.as_view(), name='plant-detail'),

#     path('observations/', views.ObservationListCreateAPIView.as_view(), name='observation-list-create'),
#     path('observations/<int:pk>/', views.ObservationRetrieveUpdateDestroyAPIView.as_view(), name='observation-detail'),
# ]

# For ModelViewSet
from rest_framework.routers import DefaultRouter
from .views import PlantViewSet, ObservationViewSet

router = DefaultRouter()
router.register(r'plants', PlantViewSet, basename='plant')
router.register(r'observations', ObservationViewSet, basename='observation')

urlpatterns = router.urls