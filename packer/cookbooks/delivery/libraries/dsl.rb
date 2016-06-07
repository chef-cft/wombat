

# Mixin DeliveryDemo::Helper to Recipes & Resources
::Chef::Recipe.send(:include, Delivery::Helper)
::Chef::Resource.send(:include, Delivery::Helper)