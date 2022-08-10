db.createUser(
    {
        //set user name here
        user: :""
        //set password for user here
        pwd: "" 
        roles: [
            {
                role: "readWrite",
                db: "init_db"
            }
        ]
    }
)
