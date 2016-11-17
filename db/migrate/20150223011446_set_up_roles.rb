class SetUpRoles < ActiveRecord::Migration
  def migrate(direction)
    super

    # moved to seeds.rb
    # if direction == :up        
    #   role = Role.create!(name: 'Super Admin')
      
    #   #create a universal permission
    #   perm = Permission.create!(name: 'All', subject_class: "all", action: "all")
      
    #   user = User.where(email: 'admin@example.com').first
    #   user.roles << role       

    #   role.permissions << perm      
    # end
  end

  def self.up
    create_table :roles do |t|
      t.string :name
      t.timestamps
    end

    create_table :roles_users, :id => false do |t|
      t.references :role, :user
    end

    create_table :permissions do |t|
      t.string :name
      t.string :action
      t.string :subject_class
      t.timestamps
    end

    create_table :permissions_roles, :id => false do |t|
      t.references :role, :permission
    end

  end
 
  def self.down
    drop_table :roles
    drop_table :roles_users
    drop_table :permissions
    drop_table :permissions_roles
  end
end