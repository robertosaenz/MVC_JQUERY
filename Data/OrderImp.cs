using Dapper;
using MASTERDETAIL.Models;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Cryptography;

namespace MASTERDETAIL.Data
{
    public class OrderImp : IOrder
    {
        private readonly Connection _connection;

        public OrderImp(Connection connection)
        {
            _connection = connection;
        }
        public List<OrderMaster> GetOrders()
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                return conexion.Query<OrderMaster>("GET_ORDERS", commandType: CommandType.StoredProcedure).ToList();
            }
        }
        public int CreateOrderMaster(OrderMaster order) 
        {
            int Rsp = 0;
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();
                parametros.Add("@CustomerName", order.CustomerName, DbType.String);
                parametros.Add("@Address", order.Address, DbType.String);
                parametros.Add("@Rsp", dbType: DbType.Int32, direction: ParameterDirection.Output);
                conexion.Execute("CREATE_ORDER_MASTER", parametros, commandType: CommandType.StoredProcedure);
                Rsp = parametros.Get<int>("@Rsp");

                return Rsp;
            }
        }

        public void UpdateOrderMaster(OrderMaster orderMaster) 
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();

                parametros.Add("@MasterId", orderMaster.MasterId, DbType.Int32);
                parametros.Add("@CustomerName", orderMaster.CustomerName, DbType.String);
                parametros.Add("@Address", orderMaster.Address, DbType.String);
                conexion.Execute("UPDATE_ORDER_MASTER", parametros, commandType: CommandType.StoredProcedure);

            }
        }

        public void CreateOrderDetails(OrderDetail orderDetail)
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();
                parametros.Add("@MasterId", orderDetail.MasterId, DbType.String);
                parametros.Add("@ProductName", orderDetail.ProductName, DbType.String);
                parametros.Add("@Quantity", orderDetail.Quantity, DbType.Int32);
                parametros.Add("@Amount", orderDetail.Amount, DbType.Decimal);
                conexion.Execute("CREATE_ORDER_DETAILS", parametros, commandType: CommandType.StoredProcedure);
            }
        }

        public void UpdateOrderDetails(OrderDetail orderDetail)
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();
                parametros.Add("@DetailId", orderDetail.DetailId, DbType.Int32);
                parametros.Add("@MasterId", orderDetail.MasterId, DbType.Int32);
                parametros.Add("@ProductName", orderDetail.ProductName, DbType.String);
                parametros.Add("@Quantity", orderDetail.Quantity, DbType.Int32);
                parametros.Add("@Amount", orderDetail.Amount, DbType.Decimal);
                conexion.Execute("UPDATE_ORDER_DETAILS", parametros, commandType: CommandType.StoredProcedure);
            }
        }

        public OrderMaster GetOrderMaster(int id)
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();
                parametros.Add("@MasterId", id, DbType.Int32);
                return conexion.QueryFirstOrDefault<OrderMaster>("GET_ORDER_MASTER", parametros, commandType: CommandType.StoredProcedure);
            }
        }

        public List<OrderDetail> GetOrderDetails(int id)
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();
                parametros.Add("@MasterId", id, DbType.Int32);
                return conexion.Query<OrderDetail>("GET_ORDER_DETAILS", parametros, commandType: CommandType.StoredProcedure).ToList();
            }
        }

        public OrderDetail GetOrderDetail(int id)
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();
                parametros.Add("@DetailId", id, DbType.Int32);
                return conexion.QueryFirstOrDefault<OrderDetail>("GET_ORDER_DETAIL", parametros, commandType: CommandType.StoredProcedure);
            }
        }

        public void DeleteOrderDetail(int id)
        {
            using (var conexion = _connection.ObtenerConexion())
            {
                var parametros = new DynamicParameters();
                parametros.Add("@DetailId", id, DbType.Int32);
                conexion.Execute("DELETE_ORDER_DETAIL", parametros, commandType: CommandType.StoredProcedure);
            }
        }
    }
}
