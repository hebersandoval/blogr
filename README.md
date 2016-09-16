Building a simple blog application that has a User, Post, Comment, Category model. Here is the overview:

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

 I'll start with generating some static pages, like and about and contact page.
