using MASTERDETAIL.Models;
using System.Collections.Generic;

namespace MASTERDETAIL.Data
{
    public interface IOrder
    {
        List<OrderMaster> GetOrders();
        int CreateOrderMaster(OrderMaster order);
        void UpdateOrderMaster(OrderMaster orderMaster);
        OrderMaster GetOrderMaster(int id);
        void CreateOrderDetails(OrderDetail orderDetail);
        void UpdateOrderDetails(OrderDetail orderDetail);
        List<OrderDetail> GetOrderDetails(int id);
        OrderDetail GetOrderDetail(int id);
        void DeleteOrderDetail(int id);
    }
}
