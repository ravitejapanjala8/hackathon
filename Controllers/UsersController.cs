using Microsoft.AspNetCore.Mvc;
using SampleApi.Models;

namespace SampleApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        // In-memory data store for demo purposes
        // Note: Using a simple list with lock for thread safety in this demo
        // For production, use a proper database
        private static readonly List<User> _users = new()
        {
            new User { Id = 1, Name = "John Doe", Email = "john@example.com" },
            new User { Id = 2, Name = "Jane Smith", Email = "jane@example.com" },
            new User { Id = 3, Name = "Bob Johnson", Email = "bob@example.com" }
        };
        private static readonly object _lock = new object();

        /// <summary>
        /// Get all users
        /// </summary>
        [HttpGet]
        public ActionResult<IEnumerable<User>> GetUsers()
        {
            lock (_lock)
            {
                return Ok(_users.ToList());
            }
        }

        /// <summary>
        /// Get user by ID
        /// </summary>
        [HttpGet("{id}")]
        public ActionResult<User> GetUser(int id)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.Id == id);
                if (user == null)
                {
                    return NotFound(new ErrorResponse { Error = "User not found" });
                }
                return Ok(user);
            }
        }

        /// <summary>
        /// Create a new user
        /// </summary>
        [HttpPost]
        public ActionResult<User> CreateUser([FromBody] UserInput userInput)
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(userInput.Name))
            {
                return BadRequest(new ErrorResponse { Error = "Name is required" });
            }
            if (string.IsNullOrWhiteSpace(userInput.Email))
            {
                return BadRequest(new ErrorResponse { Error = "Email is required" });
            }
            if (!IsValidEmail(userInput.Email))
            {
                return BadRequest(new ErrorResponse { Error = "Invalid email format" });
            }

            lock (_lock)
            {
                var newUser = new User
                {
                    Id = _users.Any() ? _users.Max(u => u.Id) + 1 : 1,
                    Name = userInput.Name,
                    Email = userInput.Email
                };
                _users.Add(newUser);
                return CreatedAtAction(nameof(GetUser), new { id = newUser.Id }, newUser);
            }
        }

        /// <summary>
        /// Update an existing user
        /// </summary>
        [HttpPut("{id}")]
        public ActionResult<User> UpdateUser(int id, [FromBody] UserInput userInput)
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(userInput.Name))
            {
                return BadRequest(new ErrorResponse { Error = "Name is required" });
            }
            if (string.IsNullOrWhiteSpace(userInput.Email))
            {
                return BadRequest(new ErrorResponse { Error = "Email is required" });
            }
            if (!IsValidEmail(userInput.Email))
            {
                return BadRequest(new ErrorResponse { Error = "Invalid email format" });
            }

            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.Id == id);
                if (user == null)
                {
                    return NotFound(new ErrorResponse { Error = "User not found" });
                }

                user.Name = userInput.Name;
                user.Email = userInput.Email;
                return Ok(user);
            }
        }

        /// <summary>
        /// Delete a user
        /// </summary>
        [HttpDelete("{id}")]
        public ActionResult<DeleteResponse> DeleteUser(int id)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.Id == id);
                if (user == null)
                {
                    return NotFound(new ErrorResponse { Error = "User not found" });
                }

                _users.Remove(user);
                return Ok(new DeleteResponse { Message = $"User {id} deleted successfully" });
            }
        }

        /// <summary>
        /// Simple email validation
        /// </summary>
        private static bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }
    }
}
