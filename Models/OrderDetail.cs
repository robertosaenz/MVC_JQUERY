namespace MASTERDETAIL.Models
{
    public class OrderDetail
    {
        public int DetailId { get; set; }
        public int MasterId { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal Amount { get; set; }

        public virtual OrderMaster OrderMaster { get; set; }
    }
}
