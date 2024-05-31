using MASTERDETAIL.Data;
using MASTERDETAIL.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Linq;
using System.Net;
//using System.Web.Mvc;
//using System.Web.Http;

namespace MASTERDETAIL.Controllers
{
    public class OrderController : Controller
    {
        private readonly IOrder _iorder;

        public ActionResult Index()
        {
            return View();
        }

        public OrderController(IOrder iorder)
        {
            _iorder = iorder;
        }

        [HttpPost]
        public ActionResult getOrders()
        {
            //var draw = Request.Form["draw"].FirstOrDefault();

            var model = _iorder.GetOrders();

            return Json(new
            {
                //draw = draw,
                recordsFiltered = model.Count,
                recordsTotal = model.Count,
                data = model
            });
        }

        public ActionResult saveOrder(OrderViewModel order)
        {
            var rspMasterId = 0;

            var orderMaster = new OrderMaster();
            orderMaster.CustomerName = order.CustomerName;
            orderMaster.Address = order.Address;

            if (order.MasterId != 0)
            {
                orderMaster.MasterId = order.MasterId;
                _iorder.UpdateOrderMaster(orderMaster);
                rspMasterId = orderMaster.MasterId;
            }
            else 
            {
                rspMasterId = _iorder.CreateOrderMaster(orderMaster);
            }

            //Process Order details

            //if (order.OrderDetails.Any())
            //{
                if (order.OrderDetails != null) 
                {
                    foreach (var item in order.OrderDetails)
                    {
                        var orderDetails = new OrderDetail();
                        orderDetails.MasterId = rspMasterId;
                        orderDetails.Amount = decimal.Parse(item.Amount);
                        orderDetails.ProductName = item.ProductName;
                        orderDetails.Quantity = int.Parse(item.Quantity);

                        if (item.DetailId != 0)
                        {
                            orderDetails.DetailId = item.DetailId;
                            _iorder.UpdateOrderDetails(orderDetails);
                        }
                        else { _iorder.CreateOrderDetails(orderDetails); }


                    }
                }
            //}

            try
            {
                //if (db.SaveChanges() > 0)
                //{
                    return Json(new { error = false, message = "Order saved successfully" });
                //}
            }
            catch (Exception ex)
            {
                return Json(new { error = true, message = ex.Message });
            }

            return Json(new { error = true, message = "An unknown error has occured" });
        }

        public ActionResult getSingleOrder(int orderId)
        {
            var model = _iorder.GetOrderMaster(orderId);

            if (model != null)
            {
                model.OrderDetails = _iorder.GetOrderDetails(orderId);
            }

            return Json(new { result = model });
        }

        public ActionResult deleteOrderItem(int id)
        {
            var orderDetail = _iorder.GetOrderDetail(id);

            if (null != orderDetail)
            {
                _iorder.DeleteOrderDetail(id);
                return Json(new { error = false });
            }
            return Json(new { error = true });
        }

        public ActionResult getSingleOrderDetail(int id)
        {
            var orderDetail = _iorder.GetOrderDetail(id);

            return Json(new { result = orderDetail });
        }

        public ActionResult updateOrder(Guid orderId)
        {
            return null;
        }
    }
}
