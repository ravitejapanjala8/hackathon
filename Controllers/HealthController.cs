using Microsoft.AspNetCore.Mvc;
using SampleApi.Models;

namespace SampleApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthController : ControllerBase
    {
        [HttpGet]
        public ActionResult<HealthResponse> Get()
        {
            return Ok(new HealthResponse
            {
                Status = "healthy",
                Timestamp = DateTime.UtcNow,
                Service = "Sample API"
            });
        }
    }
}
