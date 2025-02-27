import 'package:flutter/material.dart';
  

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget{ 
  const HomeAppBar ({super.key});
  
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  @override
  
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      title:  Text(
        'CodEd',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        ),
    actions: [
      Stack(
        children:[
          IconButton(
            onPressed: () {},
            icon:  Icon(Icons.favorite,
            color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Positioned(
            right:8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '0',
                style: TextStyle(
                  fontSize: 10,
                  color:  Colors.white ,
                ),
                textAlign: TextAlign.center,
              )
            ),
          )
    ],
        
      ) ,
    ],
    );
   
  }
}