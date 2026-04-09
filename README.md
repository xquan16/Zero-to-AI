# 🧠 Zero to AI - Learning Platform

Zero to AI is a comprehensive, full-stack web application designed to provide the fundamentals knowledges of Artificial Intelligence. Built with ASP.NET, the platform features role-based access control, interactive learning modules, and a fully integrated, context-aware AI Chatbot.

## ✨ Key Features
* **Context-Aware AI Tutor (Zoa):** A floating AI chatbot powered by Gemini that understands the user's role and current page context.
* **AI Command Center:** A dashboard for Admins that analyzes student metrics and drafts automated intervention emails for at-risk students.
* **Role-Based Access Control (RBAC):** Distinct interfaces, privileges, and database access for Admins, Editors, and Members.
* **Interactive Modules:** Includes dynamic courses, hands-on simulations, and quizzes.
* **AI Image Generation:** Integrated with Hugging Face's FLUX.1 model to allow users to generate custom profile avatars.
* **Role-Based Access Control (RBAC):** Distinct interfaces and privileges for Admins, Editors, and Members.
* **Context-Aware AI Tutor (Zoa):** A floating AI chatbot that understands the user's role and current page context to provide tailored assistance.
* **Interactive Modules:** Includes dynamic courses, hands-on simulations, and quizzes.
* **AI Image Generation:** Integrated with Hugging Face's FLUX.1 model to allow users to generate custom profile avatars.
* **Admin Monitor:** A comprehensive dashboard with Chart.js analytics and AI-driven insights to identify at-risk students.

## ⚙️ Setup & Installation Instructions

Because this project utilizes live AI models and a local SQL database, you must configure the environment before running the application.

### 1. Database Configuration
This project includes a complete SQL Server database script containing the schema and default data.
1. Open SQL Server Management Studio (SSMS).
2. Open the **`Database_Setup.sql`** file located inside the **`App_Data`** folder of this repository.
3. Execute the script. It will automatically create a database named `ZerotoAI` and populate it.
4. Open the project's `Web.config` file and update the `<connectionStrings>` block to point to your local SQL Server instance and the new `ZerotoAI` database.

### 2. Login Credentials
The passwords in the database are secured using BCrypt hashing. Default login credentials for the Admin, Editor, and Member accounts are provided in the **`userPassword.txt`** file, located inside the **`App_Data`** folder.

### 3. API Key Configuration
This project includes a complete SQL Server database script containing the schema and default data (including sample users, courses, and questions).
1. Open SQL Server Management Studio (SSMS).
2. Create a new, empty database named `ZerotoAI`.
3. Open and execute the included **`Database_Setup.sql`** script against this new database.
4. Open the project's `Web.config` file and update the `<connectionStrings>` block to match your local SQL Server instance.

### 2. API Key Configuration
For security reasons, the live API keys have been scrubbed from this repository. You must provide your own keys in the `Web.config` file to enable the AI features.

Locate the `<appSettings>` section in `Web.config` and populate the following values:
* `GeminiApiKey`: Your Google AI Studio key (Powers the Admin Command Center).
* `ZoaApiKey`: A secondary Google AI Studio key (Powers the Zoa Chatbot).
* `HuggingFaceToken`: Your Hugging Face Bearer token (Powers the Profile Avatar generator).
* `EmailAppPassword`: A Gmail App Password (Used by the Admin panel to send intervention emails).

### 4. Running the Application
1. Open the `.sln` file in Visual Studio.
2. Build the solution (`Ctrl + Shift + B`) to restore any NuGet packages.
3. Run the application via IIS Express.

### 3. Running the Application
1. Open the `.sln` file in Visual Studio.
2. Build the solution (`Ctrl + Shift + B`) to restore any NuGet packages.
3. Run the application via IIS Express. 

*(Note: Default login credentials for the Admin, Editor, and Member roles can be found in the `Users` table of the database).*
