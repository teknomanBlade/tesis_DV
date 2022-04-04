using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class Item : MonoBehaviour
{
    public GameObject Interact()
    {
        gameObject.GetComponent<Renderer>().enabled = false;
        gameObject.GetComponent<Collider>().enabled = false;
        return gameObject;
    }

    public void Drop()
    {
        gameObject.GetComponent<Renderer>().enabled = true;
        gameObject.GetComponent<Collider>().enabled = true;
    }

    public void FollowPlayer(Vector3 playerPos)
    {
        transform.position = playerPos;
    }
}
