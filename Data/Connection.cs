using System.Data.SqlClient;
using System.Drawing;

namespace MASTERDETAIL.Data
{
    public class Connection
    {
        private readonly string _connectionString;

        public Connection(string value) 
        {
            _connectionString = value;
        }
        public SqlConnection ObtenerConexion()
        {
            var conexion = new SqlConnection(_connectionString);
            conexion.Open();
            return conexion;
        }
    }
}
