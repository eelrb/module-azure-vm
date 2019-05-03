# Configure the Microsoft Azure Provider
provider "azurerm" {}


# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${resource_group_name}"
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${resource_group_name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = "${resource_group_name}"
    network_interface_ids = ["${network_interface_id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF8bUzOyB88DmIF6Tb7SDoPo+9yw/ZlJgS9zyqeq+S21ubF5KX0Dq3AH8n/Ge8huGbNk2k00m2VBce5QzDwHNg2wzS550D0rZ6b1ObWAIO2m+evJeAUdMrghUqZXzqKaLW43PxZ/379JkLC7K8Bnhs661cpQbMAzgRfcRf8TPb4Fo1Zsuv0W3twZRPATxryhJ3CCBhG5/JTatiKturdJO+LyJMd4oHb8Idx4l66sd80kN9t+FMCU1q3gWPX7SJ/Ci4Pzy1GDvkEfepmUuNiqk6kFazPQ0IE0g9XTiwbKbt/Ca1mPAyovF+sO6tukFN8l3yOPowPWJ0b7sdZQT6tFFlT4ITuggawJJZOIUoSrMTKKyFWVH8NFNjY7fKH8hzYL8BRA1ej2KcMsjeyh7LAw1IQo8WK2IUM8d2hpFHmNEaND6ZU/jWMkWDRxEu5FjStzPyPdvuK041ORlkwgFz3MjVze8EfrEoyXt+D8N1pZujZ8RfundMUxLaMGkvdc+yd2b9LqffnYkdk4rSxb825bKWctgp1BihWzCR8LbKmt+dKl55/GEKmh+JyeT7PshNYuziVsrbUK6n19bfy1mhodwlblaYo098U/AK1wbaBXhFeB4QRIYJx/Z224tLnUwD/0Bk98CJaow0VzKzEoSIT68OMDFiMZELxpMyDpLytmPrkw=="
        }
    }

    identity {
    type = "SystemAssigned"
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}
