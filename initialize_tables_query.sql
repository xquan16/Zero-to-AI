-- 1. Users Table (Handles Auth & Roles)
CREATE TABLE [dbo].[Users] (
    [UserID]         INT            IDENTITY (1, 1) NOT NULL,
    [Username]       NVARCHAR (50)  NOT NULL,
    [Email]          NVARCHAR (100) NOT NULL UNIQUE,
    [Password]       NVARCHAR (50)  NOT NULL, -- Plain text for assignment; Hash in real world
    [Role]           NVARCHAR (20)  NOT NULL DEFAULT 'Member', -- 'Member', 'Editor', 'Admin'
    [ProfilePicture] NVARCHAR (MAX) NULL,
    [CreatedAt]      DATETIME       DEFAULT GETDATE(),
    [IsBanned]       BIT            DEFAULT 0, -- Supports the "Ban User" feature 
    PRIMARY KEY CLUSTERED ([UserID] ASC)
);

-- 2. Categories Table (The "Domains" like Machine Learning, Robotics)
CREATE TABLE [dbo].[Categories] (
    [CategoryID]   INT            IDENTITY (1, 1) NOT NULL,
    [CategoryName] NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

-- 3. Articles Table (Educational Content)
CREATE TABLE [dbo].[Articles] (
    [ArticleID]   INT            IDENTITY (1, 1) NOT NULL,
    [Title]       NVARCHAR (100) NOT NULL,
    [Content]     NVARCHAR (MAX) NOT NULL, -- Stores HTML content
    [CategoryID]  INT            NOT NULL,
    [AuthorID]    INT            NOT NULL, -- The Editor who wrote it
    [Status]      NVARCHAR (20)  DEFAULT 'Draft', -- 'Draft', 'Published', 'Unpublished'
    [ImageURL]    NVARCHAR (200) NULL,
    [PublishDate] DATETIME       DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([ArticleID] ASC),
    FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID]),
    FOREIGN KEY ([AuthorID]) REFERENCES [dbo].[Users] ([UserID])
);

-- 4. TechNews Table (For Admin Dashboard)
CREATE TABLE [dbo].[TechNews] (
    [NewsID]      INT            IDENTITY (1, 1) NOT NULL,
    [Title]       NVARCHAR (100) NOT NULL,
    [LinkURL]     NVARCHAR (300) NOT NULL,
    [Source]      NVARCHAR (50)  NULL, -- e.g., 'Wired', 'BBC'
    [PublishDate] DATETIME       DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([NewsID] ASC)
);

-- 5. Quizzes Table (Assessments linked to Categories)
CREATE TABLE [dbo].[Quizzes] (
    [QuizID]     INT            IDENTITY (1, 1) NOT NULL,
    [Title]      NVARCHAR (100) NOT NULL,
    [CategoryID] INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([QuizID] ASC),
    FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID])
);

-- 6. Questions Table (The actual content of the quizzes)
CREATE TABLE [dbo].[Questions] (
    [QuestionID]    INT            IDENTITY (1, 1) NOT NULL,
    [QuizID]        INT            NOT NULL,
    [QuestionText]  NVARCHAR (300) NOT NULL,
    [OptionA]       NVARCHAR (100) NOT NULL,
    [OptionB]       NVARCHAR (100) NOT NULL,
    [OptionC]       NVARCHAR (100) NOT NULL,
    [OptionD]       NVARCHAR (100) NOT NULL,
    [CorrectAnswer] NVARCHAR (1)   NOT NULL, -- 'A', 'B', 'C', or 'D'
    PRIMARY KEY CLUSTERED ([QuestionID] ASC),
    FOREIGN KEY ([QuizID]) REFERENCES [dbo].[Quizzes] ([QuizID])
);

-- 7. UserProgress Table (History & Certificates)
CREATE TABLE [dbo].[UserProgress] (
    [ProgressID]    INT      IDENTITY (1, 1) NOT NULL,
    [UserID]        INT      NOT NULL,
    [QuizID]        INT      NOT NULL,
    [Score]         INT      NOT NULL,
    [CompletedDate] DATETIME DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([ProgressID] ASC),
    FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID]),
    FOREIGN KEY ([QuizID]) REFERENCES [dbo].[Quizzes] ([QuizID])
);

-- 8. SavedArticles (NEW: Matches "Preferences List" requirement )
CREATE TABLE [dbo].[SavedArticles] (
    [SavedID]   INT      IDENTITY (1, 1) NOT NULL,
    [UserID]    INT      NOT NULL,
    [ArticleID] INT      NOT NULL,
    [SavedDate] DATETIME DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([SavedID] ASC),
    FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID]),
    FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[Articles] ([ArticleID])
);

-- 9. Feedback (NEW: Matches Admin's "View and respond feedback" task )
CREATE TABLE [dbo].[Feedback] (
    [FeedbackID] INT            IDENTITY (1, 1) NOT NULL,
    [UserID]     INT            NOT NULL,
    [Subject]    NVARCHAR (100) NULL,
    [Message]    NVARCHAR (MAX) NOT NULL,
    [AdminReply] NVARCHAR (MAX) NULL, -- Stores the admin's response
    [Status]     NVARCHAR (20)  DEFAULT 'Pending', -- 'Pending', 'Replied'
    [SentDate]   DATETIME       DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([FeedbackID] ASC),
    FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);