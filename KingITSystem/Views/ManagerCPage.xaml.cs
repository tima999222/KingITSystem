using System.Windows;
using System.Windows.Controls;

namespace KingITSystem.Views
{
    /// <summary>
    /// Логика взаимодействия для ManagerCPage.xaml
    /// </summary>
    public partial class ManagerCPage : Page
    {
        public ManagerCPage()
        {
            InitializeComponent();
        }

        private void MallsButton_Click(object sender, RoutedEventArgs e)
        {
            ManagerCFrame.NavigationService.Navigate(new MallsPage());
        }

        private void PavilionsButton_Click(object sender, RoutedEventArgs e)
        {
            ManagerCFrame.NavigationService.Navigate(new PavilionsPage());
        }
    }
}
