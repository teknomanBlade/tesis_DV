using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFO : MonoBehaviour
{
    public Vector3 checkCubePos = new Vector3(0f, 4f, 0f);
    public Vector3 checkCubeExt = new Vector3(4f, 4f, 4f);
    public Vector3 startPos;
    public Vector3 endPos;

    public float spawnTimer = 10f;
    public GameObject grayPrefab;
    public Gray currentGray;
    public float timeLimit;
    public float timer;


    private void Start()
    {
        GameVars.Values.soundManager.PlaySound("UFOBuzz", 0.4f, true);
        StartCoroutine("SpawnGrey");
    }

    private void Update()
    {
        if (currentGray != null) SpawnGreyLerp();
        if (timer >= timeLimit)
        {
            currentGray.AwakeGray();
            currentGray = null;
            timer = 0;
        }
    }

    IEnumerator SpawnGrey()
    {
        yield return new WaitForSeconds(spawnTimer);
        if (!Physics.CheckBox(transform.position - checkCubePos, checkCubeExt, Quaternion.identity, 1 << LayerMask.NameToLayer("Enemy")))
        {
            currentGray = Instantiate(grayPrefab, transform.position - startPos, Quaternion.identity).GetComponent<Gray>();
        }
        StartCoroutine("SpawnGrey");
    }

    public void SpawnGreyLerp()
    {
        currentGray.SetPos(Vector3.Lerp(transform.position - startPos, transform.position - endPos, timer / timeLimit));
        timer += Time.deltaTime;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireCube(transform.position - checkCubePos, checkCubeExt);
        Gizmos.DrawWireCube(transform.position - startPos, new Vector3(0.5f, 0.5f, 0.5f));
        Gizmos.DrawWireCube(transform.position - endPos, new Vector3(0.5f, 0.5f, 0.5f));
    }
}
