//using StarterAssets;
//using System.Collections;
//using System.Collections.Generic;
//using System.Linq;
//using UnityEngine;
//using UnityEngine.SceneManagement;

//public class TriggerMainStairs : MonoBehaviour
//{
//    public GameObject player;
//    // Start is called before the first frame update
//    void Awake()
//    {
//        player = FindObjectOfType<FirstPersonController>().gameObject;
//        DontDestroyOnLoad(player);
//    }

//    // Update is called once per frame
//    void Update()
//    {
        
//    }

//    private void OnTriggerEnter(Collider other)
//    {
//        if (other.gameObject.GetComponent<FirstPersonController>() != null)
//        {
//            if (SceneManager.GetActiveScene().buildIndex == 0)
//            {
//                SceneManager.LoadScene(1);
//                player.tag = "MainPlayer";
//            }
//            else
//            {
//                SceneManager.LoadScene(0);
//                var playerDuplicate = FindObjectsOfType<FirstPersonController>().ToList();
//                //if (playerDuplicate != null) Destroy(playerDuplicate);
//            }
                
//        }
//    }
//}
