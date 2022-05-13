using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryItem : Item
{
    public int myCraftingID; //pasar a get set en Item
    public GameObject myPrefab; //pasar a get set en Item
    public float timeLimit = 3f;
    protected float timer = 0f;
    protected Vector3 startPos;
    protected bool startDying = false;
    protected float distanceLimit = 0.3f;

    protected override void Start()
    {
        timeLimit = GameVars.Values.itemPickUpLerpSpeed;
    }

    protected override void Update()
    {
        if (startDying) Move();
    }

    public void Move()
    {
        Vector3 playerPos = GameVars.Values.GetPlayerPos();
        transform.position = Vector3.Lerp(startPos, playerPos, timer / timeLimit);
        timer += Time.deltaTime;
        if (Vector3.Distance(transform.position, playerPos) <= distanceLimit)
        {
            startDying = false;
            Die();
        }
    }

    public override void Interact()
    {
        gameObject.GetComponent<Collider>().enabled = false;
        startPos = transform.position;
        startDying = true;
    }

    public void Die()
    {
        GameVars.Values.PlayPickUpSound();
        gameObject.SetActive(false);
        
        //Destroy(gameObject);
    }

    public void SetActiveAgain()
    {
        gameObject.SetActive(true);
    }

    public void EnableColliderAgain()
    {
        gameObject.GetComponent<Collider>().enabled = true;
    }
}
