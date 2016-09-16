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

 Here we're just generating a action called `new` in the `users_controller`.
