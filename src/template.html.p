<!DOCTYPE html>
<html lang="en">
   <head>
      <link rel="stylesheet" href="/styles.css">
      <meta charset="UTF-8"/>
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/default.min.css">
      <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/languages/racket.min.js"></script>
      <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
      <script>
        hljs.highlightAll();
      </script>
   </head>
   <body class="page">
      <div class="container">
         <div class="title-bar">
            <div class="header">
               Stone Liu
            </div>
            <div class="tabs">
               <a href="/index.html" class=tab>home</a> 
               <a href="/blog" class=tab>journal</a> 
               <a href="/scratchpad" class=tab>scratchpad</a> 
               <a href="https://github.com/stoneliuCS/resume/blob/main/StoneLiu_Resume.pdf" class=tab>resume</a>
            </div>
         </div>
         <hr/>
         ◊(->html ◊doc)
         <div class="footer">
            <a href="https://github.com/stoneliuCS" class="footer-item">github: @stoneliuCS</a>
            <a href="https://www.linkedin.com/in/stone-liu/" class="footer-item">linkedin: @stone-liu</a>
            <a href="mailto: liu.sto@northeastern.edu" class="footer-item">email: liu{dot}sto{at}northeastern.edu</a>
         </div>
      </div>
   </body>
</html>
