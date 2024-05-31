using System.Collections.Generic;

namespace MASTERDETAIL.Models
{
    public class OrderViewModel
    {
        public int MasterId { get; set; }
        public string CustomerName { get; set; }
        public string Address { get; set; }
        public string OrderDate { get; set; }
        public List<OrderDetailsViewModel> OrderDetails { get; set; }
    }

    public class OrderDetailsViewModel
    {
        public int DetailId { get; set; }
        public int MasterId { get; set; }
        public string ProductName { get; set; }
        public string Quantity { get; set; }
        public string Amount { get; set; }

    }
}
