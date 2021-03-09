<?php

use Illuminate\Support\Facades\Route;

use Phpfastcache\Helper\Psr16Adapter;
Route::get('/', function () {
    return view('welcome');
});
Route::get('/a', function () {

    $instagram = \InstagramScraper\Instagram::withCredentials(new \GuzzleHttp\Client(
        ['proxy' => 'HTTP://14.207.84.75:8080','defaults' => [
            'verify' => false
        ]]
    ),
    env('IG_ACCOUNT'),env('IG_PASSWORD') , new Psr16Adapter('Files'));
    $instagram->login(); 
    $instagram->saveSession();  

    $nonPrivateAccountMedias = $instagram->getPaginateMediaCommentsByCode('CL6CVqlB7fE', 100 ,null);

    dd($nonPrivateAccountMedias);
    echo $nonPrivateAccountMedias[0]->getLink();

});
