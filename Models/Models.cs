namespace SampleApi.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }

    public class UserInput
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }

    public class HealthResponse
    {
        public string Status { get; set; } = "healthy";
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
        public string Service { get; set; } = "Sample API";
    }

    public class DeleteResponse
    {
        public string Message { get; set; } = string.Empty;
    }

    public class ErrorResponse
    {
        public string Error { get; set; } = string.Empty;
    }
}
