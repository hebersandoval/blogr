Building a simple blog application that has a User, Post, Comment, Category model. Here is the overview:

```
User
 -id
 -name
 -email
 -password_digest

Profile #=> many not implement
 -name
 -bio
 -bod
 -color
 -twitter
 -user_id

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

 ```
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

 The User Model.

 ```
 $ rails generate controller Users new
 ```

 Here we're just generating a action called `new` in the `users_controller`. As it stands, creating a form to sign up a new user wont work, because their information will not be saved anywhere. In order to do this, we need to store our information in a database. Rails' ORM library, Active Record, can help to interact with the database, so we don't have to write raw SQL. One of the features that helps us with this is `migrations`, which allow us to define our data using Ruby classes.

 ```
 $ rails g model User name email
 ```

 This command created a `User` model and a `migration` file with a table called `users` with `name` and `email` columns.

```
class User < ActiveRecord::Base
end
```

 ```
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
