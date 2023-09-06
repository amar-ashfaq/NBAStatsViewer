using NBAStatsViewer.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Mvc;

namespace NBAStatsViewer.Controllers
{
    public class HomeController : Controller
    {
        // Store the database connection string in a private field
        private readonly string _connectionString = ConfigurationManager.ConnectionStrings["NBADbConnection"].ConnectionString;

        // Action method for the Index view
        public ActionResult Index()
        {
            // Retrieve combined data from the database and pass it to the view
            List<CombinedDataModel> combinedData = GetCombinedData();
            return View(combinedData);
        }

        // Method to fetch combined data from the database
        public List<CombinedDataModel> GetCombinedData()
        {
            List<CombinedDataModel> combinedData = new List<CombinedDataModel>();

            // Establish a connection to the database using the connection string
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();

                // Create a SQL command to execute the stored procedure "CalculateAllStats"
                using (SqlCommand command = new SqlCommand("CalculateAllStats", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Execute the command and retrieve data using a SqlDataReader
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            // Map database fields to the CombinedDataModel properties
                            combinedData.Add(new CombinedDataModel
                            {
                                Name = reader["TeamName"].ToString(),
                                Stadium = reader["Stadium"].ToString(),
                                Logo = reader["Logo"].ToString(),
                                URL = reader["URL"].ToString(),
                                Played = Convert.ToInt32(reader["Played"]),
                                Won = Convert.ToInt32(reader["Won"]),
                                Lost = Convert.ToInt32(reader["Lost"]),
                                PlayedHome = Convert.ToInt32(reader["PlayedHome"]),
                                PlayedAway = Convert.ToInt32(reader["PlayedAway"]),
                                BiggestWin = reader["BiggestWin"].ToString(),
                                BiggestLoss = reader["BiggestLoss"].ToString(),
                                LastGameStadium = reader["LastGameStadium"].ToString(),
                                LastGameDate = Convert.ToDateTime(reader["LastGameDate"]),
                                MVP = reader["MVP"].ToString()
                            });
                        }
                    }
                }
            }

            return combinedData;
        }
    }
}
