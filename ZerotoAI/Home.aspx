<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="ZerotoAI.Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="hero-section">
        <h1 class="hero-title">Master AI from Zero</h1>
        <p class="hero-subtitle">
            Zero to AI is the ultimate interactive platform for computer science students and tech enthusiasts. 
            Simulate neural networks, visualize data, and track your learning journey — all in one place.
        </p>
        
        <a href="Login.aspx" class="cta-button">
            <i class="fas fa-rocket"></i> Get Started Now
        </a>
    </div>

    <div class="content-sheet">
        <div class="about-container">
            <div class="about-text">
                <h2>About Zero to AI</h2>
                <p>
                    Zero to AI bridges the gap between theoretical computer science and practical application.
                    Designed for students, by students, our platform provides a hands-on environment to 
                    experiment with machine learning algorithms, visualize complex data structures, and 
                    master the fundamentals of Artificial Intelligence without the need for expensive hardware.
                </p>
            </div>
            <div class="about-image">
                <asp:Image ID="aboutLogo" runat="server" ImageUrl="~/images/logo.png" AlternateText="Zero to AI Logo" />
            </div>
        </div>

        <div class="features-grid">
            
            <div class="feature-card">
                <i class="fas fa-brain feature-icon"></i>
                <div class="feature-title">Interactive Simulations</div>
                <div class="feature-desc">
                    Don't just read about AI. Build and train models directly in your browser with our visual tools.
                </div>
            </div>

            <div class="feature-card">
                <i class="fas fa-chart-pie feature-icon"></i>
                <div class="feature-title">Real-time Analytics</div>
                <div class="feature-desc">
                    Track your progress with dynamic charts. See your strengths and areas for improvement instantly.
                </div>
            </div>

            <div class="feature-card">
                <i class="fas fa-laptop-code feature-icon"></i>
                <div class="feature-title">Student Dashboard</div>
                <div class="feature-desc">
                    A personalized space to manage your courses, assignments, and upcoming deadlines efficiently.
                </div>
            </div>

        </div>

        <div class="stats-row">
            <div class="stat-item">
                <h2>100+</h2> <span>Modules</span>
            </div>
            <div class="stat-item">
                <h2>500+</h2>
                <span>Active Students</span>
            </div>
            <div class="stat-item">
                <h2>24/7</h2>
                <span>AI Support</span>
            </div>
        </div>
    </div>

</asp:Content>