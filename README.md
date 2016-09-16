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
