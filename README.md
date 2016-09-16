## Building a simple blog application.

This app will have a User, Post, Comment, Category model. Here is the overview:

```
User
 -id
 -name
 -email
 -password_digest

Post
 -id
 -title
 -content
 -user_id

CategoryPost
 -id
 -category_id
 -post_id

Category
 -id
 -name

Comment
 -id
 -content
 -post_id
 -user_id
 ```

 I'll start with generating some static pages, like and about and contact page.

```
$ rails generate controller StaticPages home about contact
 ```

 Also, added some styling using the `bootstrap` gem. To use a generic HTML template, I had to use rails partial features and figure out what to put above and below the `<%= yield %>` keyword, located in the `app/views/layouts/application.html.erb` file. Once I understood the structure of the HTML, I made 3 partials, `_header.html.erb, _sidebar.html.erb, _footer.html.erb`. To use these partials, simple put `<%=render 'header' %>`, in this case, it will render the code inside this particular partial.

 ```html
 <!DOCTYPE html>
 <html>
 <head>
   <title>Blogr</title>
   <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
   <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
   <%= csrf_meta_tags %>
 </head>
 <body>
   <%= render 'layouts/header' %>
   <div class="container">
     <div class="row">
       <div class="col-sm-8 blog-main">
         <%= yield %>
       </div><!-- /.blog-main -->
       <%= render 'layouts/sidebar' %>
     </div><!-- /.row -->
   </div><!-- /.container -->
   <%= render 'layouts/footer' %>
 </body>
 </html>
 ```

 Some code was not included for brevity. If you like to clean this document a bit more, creating a partial to hold the rails defaults inside the head, would make it more readable. With some layout styles out of the way, lets start creating our models.

 ### The User Model.

 ```
 $ rails generate controller Users new
 ```

 Here we're just generating a action called `new` in the `users_controller`. As it stands, creating a form to sign up a new user wont work, because their information will not be saved anywhere. In order to do this, we need to store our information in a database. Rails' ORM library, Active Record, can help to interact with the database, so we don't have to write raw SQL. One of the features that helps us with this is `migrations`, which allow us to define our data using Ruby classes.

 ```
 $ rails g model User name email
 ```

 This command created a `User` model and a `migration` file with a table called `users` with `name` and `email` columns.

```ruby
class User < ActiveRecord::Base
end
```

 ```ruby
 class CreateUsers < ActiveRecord::Migration
   def change
     create_table :users do |t|
       t.string :name
       t.string :email

       t.timestamps null: false
     end
   end
 end
 ```

 Migrations provide a way to alter the structure of the database incrementally, so that our data model can adapt to changing requirements. Inside of the of this migration, the  `change` method determine the change to be made to the database. As noted above, `change` uses a rails method called `create_table` to create a table in the database for storing users. The `create_table` method accepts a block with one block variable, this case called `t`, for "table". Inside the block, the `create_table` method uses th `t` object to create `name` and  `email` columns in the database, both of type `string`. Here the table name is plural, `users`, even though the model name is singular, `User`, which reflects a linguistic convention followed by rails: a model represents a single user, whereas a database table consists of many users.

```
$ rails db:migrate
```

Running this command creates a file calles `db/development.sqlite3`, which is a SQLite database and `db/schema.rb` file. The `schema.rb` file is used to keep track of the structure of the database, called schema.

Looking at our `User` model, it inherites from the `ActiveRecord::Base`. This means that the `User` model automatically has all the functionality of the `ActiveRecord::Base` class. To test this, just drop in a rails console session.

```
$ rails c -s

$ user = User.new
```

And sure enough, there is the `user` object with its attributes, which represent an individual column in the database table.

```
=> #<User id: nil, name: nil, email: nil, created_at: nil, updated_at: nil>
irb(main):002:0>
```

But this doesn't mean that is object is saved in the database. It only saves in "memory". We have to tell Active Record our intent. On a side note, because we don't have any "validation" in place, yet, such as if the name field contains a value, checking its "validity", will return `true`.

```
user.valid?

=> true
```

`valid?` happens to be a method provided due to inheritance.

Lets save this new `User` object to the database, but first, add some value in its attributes.

```
$ user.save

(0.2ms)  SAVEPOINT active_record_1
 SQL (0.7ms)  INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["name", "Joe"], ["email", "j@j.com"], ["created_at", "2016-09-16 13:12:17.817497"], ["updated_at", "2016-09-16 13:12:17.817497"]]
  (0.2ms)  RELEASE SAVEPOINT active_record_1
=> true

$ user

=> #<User id: 1, name: "Joe", email: "j@j.com", created_at: "2016-09-16 13:12:17", updated_at: "2016-09-16 13:12:17">
```

The new `User` object was saved to the database when we used the `save` method, which returns `true`. Behind the scene, rails executed some SQL, as promised. At this point, any object we save should succeed because there are no validations.

If we need to change some of the attributes after the object has been save to the database, we do this like this:

```
$ user.email = "j@snailmail.com"

=> "j@snailmail.com"

$ user.save

=> #<User id: 1, name: "Joe", email: "j@snailmail.com", created_at: "2016-09-16 13:12:17", updated_at: "2016-09-16 13:50:05">
```

If we want to update multiple attributes, use the `update_attributes` method on the object you want to update, which accepts a hash.

```
user.update_attributes name: "Joe Smalls", email: "jsmalls@snailmail.com"
```

For a single attribute update:

```
user.update_attribute name: "John Smalls"
```

A handy method, if you want to find a record by its `id`, is the `find` method.

```
$ User.find(1)

User Load (0.1ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1  [["id", 1]]

=> #<User id: 1, name: "Joe", email: "j@j.com", created_at: "2016-09-16 13:12:17", updated_at: "2016-09-16 13:12:17">
```

But if you can't remember the `id` value, you can use the `find_by` method instead. `find_by` allows you to pass in a key/value pair, where the key is the attribute and the value is what is store in the database as its value.

```
User.find_by name: "Joe"

User Load (0.4ms)  SELECT  "users".* FROM "users" WHERE "users"."name" = ? LIMIT 1  [["name", "Joe"]]

=> #<User id: 1, name: "Joe", email: "j@j.com", created_at: "2016-09-16 13:12:17", updated_at: "2016-09-16 13:12:17">
```

Other options are `.first`, `.all`, which do what they say.

### Though is good to be able to create and save your data in a database, you want to control what information goes into it by using validations.

Validations will allow us to impose some constraints on values of fields in our table, like, `name` should be be non-blank and `email` should match the specific format characteristic of email addresses.

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

With this new code in our `User` model, checking if an object name attribute is valid, or has some value, will return `true` or `false`.

```
$ user = User.new(name: "", email: "jsmalls@snailmail.com")

$ user.valid?

=> false
```

Why did it failed?

```
$ user.errors.full_messages

=> ["Name can't be blank"]
```

Under the hood, rails uses the `blank?` method.

```
$ "".blank?
=> true

$ "      ".empty?
=> false

$ "      ".blank?
=> true

$ nil.blank?
=> true
```

A string of spaces it's not "empty" but it's "blank". Since the user isn't valid, an attempt to save the user to the database automatically fails.

```
(0.2ms)  SAVEPOINT active_record_1
   (0.1ms)  ROLLBACK TO SAVEPOINT active_record_1

=> false
```

This would be the same for `email`. Additionally, you can add format, length and a whole slew of validation to this field and others. As an example, lets add the following validation to `email`.

```ruby
class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
```

For this to work on the model and the database level, we need to put an index on the `email` column of the `users` table. To accomplish this, we need to make a migration.

```
$ rails g migration add_index_to_users_email
```

This generates, without the `add_index` method provided by rails:

```ruby
class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
    add_index :users, :email, unique: true
  end
end
```

By using the `add_index` method, you're adding an index on the `email` column of the `users` table. To enforce uniqueness at this level, use the option `unique: true`. Run the migration.

Here's the `schema.rb` file to verify that it worked.

```ruby
ActiveRecord::Schema.define(version: 20160916151846) do

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
```

Now, the email addresses `jsmalls@snailmail.com` and `JSmalls@SNAILMAIL.com`, will be treated the same. So if another user signs up and uses this same email in any of its flavors, it will fail.

```
user2 = User.new name: "John", email: "JSMALLS@SNAILMAIL.COM"

user2.save

(0.2ms)  SAVEPOINT active_record_1
  User Exists (0.3ms)  SELECT  1 AS one FROM "users" WHERE LOWER("users"."email") = LOWER('jsmalls@snailmail.com') LIMIT 1
   (0.1ms)  ROLLBACK TO SAVEPOINT active_record_1

=> false

$ user2.errors.full_messages

=> ["Email has already been taken"]
```


This is not the case with other databases which use case-sensitive indices. So, this example, would be considered as two different email addresses. A quick fix is to make all email addresses lowercase before the user is saved with a callback method in the  `User` model.

```ruby
class User < ActiveRecord::Base
  before_save :downcase_email
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end
end
```

The `before_save` callback method, will get invoked at a particular point in the lifecycle of an Active Record object. In this case, that point is before the object is saved.

### Adding a secure password

We'll add another attribute or field to the `User` model. This will be reflected in the column of our `users` table. The password will be store as a `hash` in the database. `hash` refers to the result of applying an irreversible hash function to input data.

The goal here is to take the password the user submits, hash it, and compare the result to the hashed value stored in the database. If the two match, then the submitted password is correct and the user is authenticated. Here, we are not comparing the raw password but a hashed password. To accomplish this will use the `bcrypt` gem. By design, the `bcrypt` algorithm produces a salted hash, which protects against two important classes of attacks (dictionary attacks and rainbow table attacks).

To use its functionality, we need to create a migration with a field in the `users` table named `password_digest` of type string. Now we are ready to hash the password with `bcrypt`, just uncomment from the Gemfile and run  `bundle install`. In the `User` model, add the `has_secure_password` macro. This macro will give you some attributes like `password`, `password_confirmation` and the method `authenticate` that returns `true` or `false`.


```ruby
class User < ActiveRecord::Base

  ...

  has_secure_password

  ...
```

#### Creating a user

```
$ user = User.create(name: "Joe", email: "jsmalls@snailmail.com", password: "guacamole", password_confirmation: "guacamole")

(0.1ms)  SAVEPOINT active_record_1
  User Exists (0.2ms)  SELECT  1 AS one FROM "users" WHERE LOWER("users"."email") = LOWER('jsmalls@snailmail.com') LIMIT 1
  SQL (0.4ms)  INSERT INTO "users" ("name", "email", "password_digest", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Joe"], ["email", "jsmalls@snailmail.com"], ["password_digest", "$2a$10$tmOEKJPtqp4SVAME7ezb9Ozn9iY2eveh.H4y6/xKtdjg7v5nKCjGa"], ["created_at", "2016-09-16 18:40:11.090582"], ["updated_at", "2016-09-16 18:40:11.090582"]]
   (0.1ms)  RELEASE SAVEPOINT active_record_1

=> #<User id: 1, name: "Joe", email: "jsmalls@snailmail.com", created_at: "2016-09-16 18:40:11", updated_at: "2016-09-16 18:40:11", password_digest: "$2a$10$tmOEKJPtqp4SVAME7ezb9Ozn9iY2eveh.H4y6/xKtdj...">
```

If you look at the output, you'll see the `password_digest` field has been hashed. In theory, our user can login in, submit his or her password, which gets checked by the `authenticate` method. Then it compares the what the result to the `password_digest` in the database.

To test it:

```
$ user.authenticate("somepassword")

=> false

$ user.authenticate("guacamole")

=> #<User id: 1, name: "Joe", email: "jsmalls@snailmail.com", created_at: "2016-09-16 18:40:11", updated_at: "2016-09-16 18:40:11", password_digest: "$2a$10$tmOEKJPtqp4SVAME7ezb9Ozn9iY2eveh.H4y6/xKtdj...">

$ !!user.authenticate("guacamole")

=> true
```
### Creating a sign up form.

Now with all these components working, we can create a sign up form that will benefit from the way we set out app thus far.

First, we need to add a route for our `users` resources and add the corresponding actions that we want to use in the `users_controller`.

```ruby
Rails.application.routes.draw do
  get 'signup', to: 'users#new'
  root 'static_pages#home'
  get 'about', to: 'static_pages#about'
  get 'contact' => 'static_pages#contact'
  resources :users
end
```

The `resources :users` route, add all the actions needed for a RESTful `users` resource, along with a number of named routes for generating URLs.

In the `users_controller`, you can use any of the actions provide. Calling the `show` action will render the code in its corresponding view, in this case, `app/views/users/show.html.erb`. The URL this action generates is `/users/:id`, where `:id` is a placeholder for a given record found in the database.

```ruby
class UsersController < ApplicationController
  def new
  end

  def show
    @user = User.find(params[:id])
  end
end
```

Notice that we are using the `params` to retrieve the user id. Here `params[:id]` is the same as the `find` method `User.find(1)`. So when the user navigates to `/users/1`, he or she will be shown the record in the database that has the value of `1`.


 The view rendered for the show action will use the instance variable `@user` to display the information the user requested. The `<%=  %>` are embedded ruby tags that allow you to share information from the show action in the `users_controller` and the `show.html>erb` in the `app/views/users`.

```html
<h1><%= @user.name %>, <%= @user.email %></h1>
```

#### Creating the form

Just like the show action in the `users_controller`, we need to let our `User` model know that we want to create a new user. We do this in the `new` action and with the form in the `app/views/users/new.html.erb`

```ruby
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end
end
```

```html
<h1>Sign up</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_for(@user) do |f| %>
      <%= f.label :name %>
      <%= f.text_field :name %>

      <%= f.label :email %>
      <%= f.email_field :email %>

      <%= f.label :password %>
      <%= f.password_field :password %>

      <%= f.label :password_confirmation, "Confirmation" %>
      <%= f.password_field :password_confirmation %>

      <%= f.submit "Create account", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>
```

Here the `form_for` is a Active Record method that can look in the `@user` object and can populate the field based on the object's attributes. It also creates the needed HTML for you. Once the user submits the form, this methods knows to send it over the `create` action in the `users_controller`.

```html
<form accept-charset="UTF-8" action="/users" class="new_user"
      id="new_user" method="post">
  <input name="utf8" type="hidden" value="&#x2713;" />
  <input name="authenticity_token" type="hidden"
         value="NNb6+J/j46LcrgYUC60wQ2titMuJQ5lLqyAbnbAUkdo=" />
  <label for="user_name">Name</label>
  <input id="user_name" name="user[name]" type="text" />

  <label for="user_email">Email</label>
  <input id="user_email" name="user[email]" type="email" />

  <label for="user_password">Password</label>
  <input id="user_password" name="user[password]"
         type="password" />

  <label for="user_password_confirmation">Confirmation</label>
  <input id="user_password_confirmation"
         name="user[password_confirmation]" type="password" />

  <input class="btn btn-primary" name="commit" type="submit"
         value="Create account" />
</form>
```

```ruby
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Blogr App!"
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

the  `create` action takes the user's input from the `new` action's template. The it checks to see if `@user.save` returns `true`, if so, it will display a message in the user's show page.

### login


### Connecting the other models

users_table

| id  | name  | email  | password_digest  |
| :-- | :---- | :----- | :--------------- |
|     |       |        |                  |
|     |       |        |                  |

Put the AR associations description here.

posts_table

 | id  | title  | content  | user_id  |
 | :-- | :----- | :------- | :------- |
 |     |        |          |          |
 |     |        |          |          |

Put the AR associations description here.

categories_posts_table

 | id  | category_id  | post_id  |
 | :-- | :----------- | :------- |
 |     |              |          |
 |     |              |          |

Put the AR associations description here.

categories_table

 | id  | name  |
 | :-- | :---- |
 |     |       |
 |     |       |


Put the AR associations description here.

comments_table

  | id  | content  | post_id  | user_id  |
  | :-- | :------- | :------- | :------- |
  |     |          |          |          |
  |     |          |          |          |

Put the AR associations description here.

The models.

```ruby
class User < ActiveRecord::Base
  has_many :posts
  has_many :replies, through: :posts, source: :comments
end
```

More stuff, up next...

```ruby
class Post < ActiveRecord::Base
  belongs_to :user
  has_many :categories_posts
  has_many :categories, through: :categories_posts
end
```

More stuff, up next...

 ```ruby
 class CategoryPost < ActiveRecord::Base
   belongs_to :category
   belongs_to :post
 end
 ```

 More stuff, up next...

 ```ruby
 class Category < ActiveRecord::Base
   has_many :categories_posts
   has_many :posts, through: :categories_posts
 end
 ```

 More stuff, up next...

 ```ruby
 class Comment < ActiveRecord::Base
   belongs_to :post
   belongs_to :user
 end
 ```

 More stuff, up next...
