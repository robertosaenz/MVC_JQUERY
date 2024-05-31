using System.Collections.Generic;

namespace MASTERDETAIL.Models
{
    public class OrderMaster
    {
        public OrderMaster()
        {
            this.OrderDetails = new List<OrderDetail>();
        }

        public int MasterId { get; set; }
        public string CustomerName { get; set; }
        public string Address { get; set; }
        public string OrderDate { get; set; }

        public virtual List<OrderDetail> OrderDetails { get; set; }
    }
}
